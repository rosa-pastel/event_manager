require 'csv'
require 'google/apis/civicinfo_v2'

def legislators_by_zipcodes(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

    begin
    legislators = civic_info.representative_info_by_address(
      address: zipcode,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    )
    legislators = legislators.officials
    legislator_names = legislators.map(&:name).join(", ")
    rescue
      'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
    end
    legislator_names
end

def clean_zipcode(zipcode)
  while zipcode.length < 5
    zipcode = "0#{zipcode}"
  end
  zipcode
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode].to_s)

  puts "#{name} #{zipcode} #{legislators_by_zipcodes(zipcode)}"
end