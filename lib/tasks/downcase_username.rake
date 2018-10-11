task :downcase_username => :environment do

  User.all.each do |user|
    user.update :username => user.username.downcase

    print '.'
  end

  puts 'done'

end
