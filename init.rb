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
phone_hash = {} # to mark unique phone occurences e.g: "5551236789": "3"  
email_hash = {} # to mark unique email occurences e.g: "test@gmail.com": "10" 
phone_or_email = {} # a combination of the above

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
        if email && !email_hash[email]
          email_hash[email] = presonId
        end
        presonId = email_hash[email] || presonId
      else
        email_hash = sync_email_hash(row, email_hash, presonId)
        presonId = email_hash[row[4]] || presonId
      end
    when 2 # phone check
      phone1 = row[2] && row[2].size && parse_phone_text(row[2])
      if (headers.size == 5)
        if phone1 && !phone_hash[phone1]
          phone_hash[phone1] = csv_file.lineno + 1
        end
      else
        phone_hash = sync_phone_hash(row, phone_hash, csv_file.lineno + 1)
      end
      presonId = phone_hash[phone1] || csv_file.lineno + 1
    when 3 # email or phone check
      if (headers.size == 5)
        phone1 = row[2] && row[2].size && parse_phone_text(row[2])
        email = row[3]
        if !phone_or_email[phone1]
          if phone_or_email[email]
            phone_or_email[phone1] = phone_or_email[email]
          else
            phone_or_email[phone1] = csv_file.lineno + 1
          end
        elsif !phone_or_email[email]
          if phone_or_email[phone1]
            phone_or_email[email] = phone_or_email[phone1]
          else
            phone_or_email[email] = csv_file.lineno + 1
          end
        end
        presonId = phone_or_email[phone1]
      else
        phone1 = row[2] && row[2].size && parse_phone_text(row[2])
        phone_or_email = sync_phone_or_email_hash(row, phone_or_email, csv_file.lineno + 1)
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

