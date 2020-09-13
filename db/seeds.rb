print "Creating Users..."
User.destroy_all

u1 = User.create!(
  name:'Jeff Winger',
  email: 'jwinger@ga.com',
  password: 'chicken'
)

u1 = User.create!(
  name:'Annie Edison',
  email: 'aedison@ga.com',
  password: 'chicken'
)

u1 = User.create!(
  name:'Troy Barnes',
  email: 'tbarnes@ga.com',
  password: 'chicken'
)

puts "Created #{ User.count } users:"
