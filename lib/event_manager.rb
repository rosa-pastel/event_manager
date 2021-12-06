require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def clean_phone_number(phone_number)
  phone_number.tr!('-.() ','')
  number_length = phone_number.length
  bad_number = true
  case number_length
  when 10
    bad_number = false
  when 11
    if phone_number[0] == '1'
      phone_number = phone_number[-10..-1] 
      bad_number = false
    end
  end
  phone_number = '0000000000' if bad_number
  phone_number
end

def registration_hours(reg_dates)
  hours = Hash.new
  24.times do |number|
    hours[number.to_s.to_sym] = 0
  end
  reg_dates.each do |value|
    t = Time.parse(value[-6..-1]).strftime("%k").tr(' ','').to_sym
    hours[t] += 1
  end
  hours
end

def registration_days(reg_dates)
  days = {}
  reg_dates.each do |value|
    d = Date.strptime(value, '%D').wday.to_s
    days.key?(d.to_sym) ? days[d.to_sym] += 1 : days[d.to_sym] = 1
  end
  days
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
reg_dates = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])
  reg_dates.push(row[:regdate])
  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)  
end
puts 'The hours that most people registered:'
puts most_popular_hours = registration_hours(reg_dates).sort_by {|key, value| value*(-1)}.to_h
puts 'The days that most people registered:'
puts most_popular_days = registration_days(reg_dates).sort_by {|key, value| value*(-1)}.to_h
puts '(Monday is 1.)'
