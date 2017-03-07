# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

project_hash = {
  1874223 => 'Ernesto',
  1978467 => 'General R&D',
  1149382 => 'LSD-JB',
  1977673 => 'FlightBot',
  1435852 => 'LSD-LG',
  97426 => 'LSD-BT',
  1435854 => 'LSD-MAT',
  1149370 => 'LSD-MBC',
  1876729 => 'Amanda',
  1143948 => 'Effie',
  811717 => 'DOCD'
}

if User.all.blank?
  User.create :username => 'James'
  User.create :username => 'Jomel'
  User.create :username => 'Julius'
  User.create :username => 'Kenneth'
end

if Project.all.blank?
  project_hash.each_pair do |id, name|
    Project.create :name => name, :pivotal_id => id
  end
end

Project.create :name => 'Unsorted', :pivotal_id => 100000
