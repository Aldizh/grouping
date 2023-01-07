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

output = [] # final output
headers = [] # header row
phone_hash = {} # to mark unique phone occurences e.g: "5551236789": "3"  
email_dict = {} # to mark unique email occurences e.g: "test@gmail.com": "10" 
phone_or_email = {} # a combination of the above

# input data
csv_file = CSV.open("#{file_name}")
csv_file.each do |row|
  if headers.size == 0
    headers = row
  else
    presonId = csv_file.lineno + 1 # row uniqueness tag
    short_file = headers.size == 5 # contains only one row with matching data
    # determine column mappers
    case matchingCriteria
    when 1 # email check
      if (short_file)
        email = get_valid_email(row)
        if email && !email_dict[email]
          email_dict[email] = presonId
        end
        presonId = email_dict[email] || presonId
      else
        email_dict = update_email_dict(row, email_dict, presonId)
        presonId = email_dict[row[4]] || presonId
      end
    when 2 # phone check
      phone1 = row[2] && row[2].size && parse_phone_text(row[2])
      if (short_file)
        if phone1 && !phone_hash[phone1]
          phone_hash[phone1] = csv_file.lineno + 1
        end
      else
        phone_hash = sync_phone_hash(row, phone_hash, csv_file.lineno + 1)
      end
      presonId = phone_hash[phone1] || csv_file.lineno + 1
    when 3 # email or phone check
      if (short_file)
        phone1 = row[2] && row[2].size && parse_phone_text(row[2])
        email = get_valid_email(row)
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
        phone_or_email = sync_phone_or_email_dict(row, phone_or_email, csv_file.lineno + 1)
        presonId = phone_or_email[phone1]
      end
    end

    presonId > 0 ? row.unshift(presonId) : row.unshift(csv_file.lineno + 1)
    output << row
  end  
end

# output results to file
headers.unshift('personID')
CSV.open('output.csv', 'w') do |csv|
  csv << headers
  output.each do |row|
    csv << row
  end
  
end

