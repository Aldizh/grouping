def parse_phone_text(text)
  if !text
    return nil
  end
  digits = text.tr('^0-9', '') # trim non-digits
  if digits[0] == '1'
    digits[0] = '' # remove U.S prefix if there is any
  end
  return digits
end

def get_file_name
  print "Please enter the input file name (e.g: input1.csv | input2.csv | input3.csv) : "
  name = gets.chomp

  return name
end

def get_criteria_from_user
  puts "Please select one of the matching criteria: \n1 -> email address \n2 -> phone number \n3 -> both"
  print ": "
  criteria = gets.chomp.to_i

  while ![1, 2, 3].include?(criteria)
    puts "Sorry, invalid selection"
    puts "Please select one of the matching criteria: \n1 -> email address \n2 -> phone number \n3 -> both"
    print ": "
    criteria = gets.chomp.to_i
  end

  puts "Thank you, your file is ready, it will be under output.csv"

  return criteria
end

# if unique return empty row, otherwise return matching row
def check_uniqueness(criteria, row, headers, unique_emails, unique_phone_numbers)
  uniq = false
  case criteria
  when 1 # email check
    headers.each_with_index do |header, index|
      if header.downcase.include?('email') && row[index-1] && row[index-1].size
        personID = unique_emails[row[index-1]]
        if personID # first occurrence that is not uniq
          row.unshift(personID)
          return row
        end
      end
    end
  when 2 # phone check
    puts unique_phone_numbers
    headers.each_with_index do |header, index|
      if header.downcase.include?('phone') && row[index-1] && row[index-1].size
        personID = unique_phone_numbers[parse_phone_text(row[index-1])]
        if personID # first occurrence that is not uniq
          row.unshift(personID)
          return row
        end
      end
    end
  when 3 # email and phone check
    headers.each_with_index do |header, index|
      personID = nil
      if header.downcase.include?('email') && row[index-1] && row[index-1].size
        if unique_emails[row[index-1]]
          personID = unique_emails[row[index-1]]
        end
      end
      if header.downcase.include?('phone') && row[index-1] && row[index-1].size
        if unique_phone_numbers[parse_phone_text(row[index-1])]
          personID = unique_phone_numbers[parse_phone_text(row[index-1])]
        end
      end
      if personID # first occurrence that is not uniq
        row.unshift(personID)
        return row
      end
    end
  end
  []
end