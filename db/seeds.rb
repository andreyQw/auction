# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# https://github.com/stympy/faker
3.times do
	User.create({
		email: Faker::Internet.email,
		password: '123456',
		phone: Faker::PhoneNumber.cell_phone,
		fname: Faker::Name.first_name,
		lname: Faker::Name.last_name,
		birthday: Faker::Date.birthday(21, 65)
	})
end
