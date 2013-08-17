orgs = [
  {
    name: 'Factor.io',
    users: [
      {
        username: 'alex',
        password: 'pass',
        api_key: 'key',
        role: 'super_admin'
      }
    ]
  }
]

orgs.each do |o|
  params = { name: o[:name] }
  org = Organization.create(params)
  puts "Created organization: #{org.to_json}"

  o[:users].each do |u|
    user = org.users.create(u)
    puts "Created user: #{user.to_json}"
  end
end
