class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
  has_many :votes

  has_secure_password validations: false

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, on: :create, length: {minimum: 5} 

  before_save :generate_slug!

  def two_factor_auth?
    !self.phone.blank?
  end

  def generate_pin!
    self.update_column(:pin, rand(10**6)) # randome 6 digit number
  end

   def remove_pin!
    self.update_column(:pin, nil)
  end

  def send_pin_to_twilio
    account_sid = 'AC3d4fcc78de34a2bbc8827773e3bdc6a1' 
    auth_token = 'd4ea49fe94103e0bf7bd15dae308f1b0' 
 
# set up a client to talk to the Twilio REST API 
    client = Twilio::REST::Client.new account_sid, auth_token 

    msg = "Hi, please input the pin to continue login: #{self.pin}"
    client.account.messages.create({
      :from => '+15207750095', 
      :to => '9727624760', 
      :body => msg})
  end


  def admin?
    self.role == 'admin'
  end

  def moderator?
    self.role == 'moderator'
  end



  def to_param
    self.slug
  end

 def generate_slug!
    the_slug = to_slug(self.username)
    user = User.find_by slug: the_slug
    count = 2
    while user && user != self
     the_slug = append_suffix(the_slug, count)
     user = User.find_by slug: the_slug
     count += 1
    end
    self.slug = the_slug.downcase
  end

  def append_suffix(str, count)
    if str.split('-').last.to_i != 0
      return str.split('-').slice(0...-1).join('-') + "-" + count.to_s
    else
      return str + "-" + count.to_s
    end
  end

  def to_slug(name)
    str = name.strip
    str.gsub!  /\s*[^A-Za-z0-9]\s*/, '-'
    str.gsub!  /-+/, "-"
    str.downcase
  end
end