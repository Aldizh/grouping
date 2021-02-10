require 'csv'
require_relative('helpers.rb')

# user input for file name
file_name = get_file_name
if !File.exists?("#{file_name}")
  puts 'Sorry, file does not exist in the system'
  return
end

# check file size < 10mb
MAX_FILE_SIZE = 10000000
if File.size("#{file_name}") > MAX_FILE_SIZE
  puts 'Sorry, file size is too big'
  return
end

matchingCriteria = get_criteria_from_user # user input for matching criteria 


data = [] # final output
headers = [] # header row
phone_hash = {}
email_hash = {}
phone_or_email = {}

# input data
csv_file = CSV.open("#{file_name}")
csv_file.each do |row|
  if headers.size == 0
    headers = row
  else
    presonId = csv_file.lineno + 1

    # determine column mappers
    case matchingCriteria
    when 1 # email check
      if (headers.size == 5)
        email = row[3] && row[3].size && row[3]
        if !email_hash[email]
          email_hash[email] = csv_file.lineno + 1
        end
        presonId = email_hash[email]
      else
        email1 = row[4] && row[4].size && row[4]
        email2 = row[5] && row[5].size && row[5]
        if email1 && !email_hash[email1]
          if email2 && email_hash[email2]
            email_hash[email1] = email_hash[email2]
          else
            email_hash[email1] = csv_file.lineno + 1
          end
        end
    
        if email2 && !email_hash[email2]
          if email1 && email_hash[email1]
            email_hash[email2] = email_hash[email1]
          else
            email_hash[email2] = csv_file.lineno + 1
          end
        end

        presonId = email_hash[row[4]].to_i
      end
    when 2 # phone check
      if (headers.size == 5)
        phone1 = row[2] && row[2].size && parse_phone_text(row[2])
        if !phone_hash[phone1]
          phone_hash[phone1] = csv_file.lineno + 1
        end
        presonId = phone_hash[phone1]
      else
        phone1 = row[2] && row[2].size && parse_phone_text(row[2])
        phone2 = row[3] && row[3].size && parse_phone_text(row[3])
        if !phone_hash[phone1]
          if phone2 && phone_hash[phone2]
            phone_hash[phone1] = phone_hash[phone2]
          else
            phone_hash[phone1] = csv_file.lineno + 1
          end
        end
    
        if !phone_hash[phone2]
          if phone1 && phone_hash[phone1]
            phone_hash[phone2] = phone_hash[phone1]
          else
            phone_hash[phone2] = csv_file.lineno + 1
          end
        end
    
        presonId = phone_hash[parse_phone_text(row[2])].to_i
      end
    when 3 # email and phone check
      # TO BE Implmented
      if (headers.size == 5)
        phone1 = row[2] && row[2].size && parse_phone_text(row[2])
        email = row[3] && row[3].size && row[3]
        if !phone_or_email[phone1] || !phone_or_email[email]
          if (phone1 && phone_or_email[phone1])
            phone_or_email[email] = phone_or_email[phone1]
          elsif (email && phone_or_email[email])
            phone_or_email[phone1] = phone_or_email[email]
          else
            phone_or_email[phone1] = csv_file.lineno + 1
            phone_or_email[email] = csv_file.lineno + 1
          end
        end
      else 
        phone1 = row[2] && row[2].size && parse_phone_text(row[2])
        phone2 = row[3] && row[3].size && parse_phone_text(row[3])
        email1 = row[4]
        email2 = row[5]
        if phone1 && !phone_or_email[phone1]
          if phone_or_email[phone2]
            phone_or_email[phone1] = phone_or_email[phone2]
          elsif phone_or_email[email1]
            phone_or_email[phone1] = phone_or_email[email1]
          elsif phone_or_email[email2]
            phone_or_email[phone1] = phone_or_email[email2]
          else
            phone_or_email[phone1] = csv_file.lineno + 1
          end
        end
        if phone2 && !phone_or_email[phone2]
          if phone_or_email[phone1]
            phone_or_email[phone2] = phone_or_email[phone1]
          elsif phone_or_email[email1]
            phone_or_email[phone2] = phone_or_email[email1]
          elsif phone_or_email[email2]
            phone_or_email[phone2] = phone_or_email[email2]
          else
            phone_or_email[phone2] = csv_file.lineno + 1
          end
        end
        if email1 && !phone_or_email[email1]
          if phone1 && phone_or_email[phone1]
            phone_or_email[email1] = phone_or_email[phone1]
          elsif phone2 && phone_or_email[phone2]
            phone_or_email[email1] = phone_or_email[phone2]
          elsif email2 && phone_or_email[email2]
            phone_or_email[email1] = phone_or_email[email2]
          else
            phone_or_email[email1] = csv_file.lineno + 1
          end
        end
        if email2 && !phone_or_email[email2]
          if phone_or_email[phone1]
            phone_or_email[email2] = phone_or_email[phone1]
          elsif phone_or_email[phone2]
            phone_or_email[email2] = phone_or_email[phone2]
          elsif phone_or_email[email1]
            phone_or_email[email2] = phone_or_email[email1]
          else
            phone_or_email[email2] = csv_file.lineno + 1
          end
        end
        puts phone_or_email
        presonId = phone_or_email[phone1]
      end
    end

    presonId > 0 ? row.unshift(presonId) : row.unshift(csv_file.lineno + 1)
    data << row
  end  
end

# output results to file
headers.unshift('personID')
CSV.open('output.csv', 'w') do |csv|
  csv << headers
  data.each do |row|
    csv << row
  end
  
end

