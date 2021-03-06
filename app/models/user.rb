class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  validates_presence_of :email
  validates_presence_of :encrypted_password

  ## Recoverable
  field :reset_password_token,   :type => String
  field :reset_password_sent_at, :type => Time

  ## Rememberable
  field :remember_created_at, :type => Time

  ## Trackable
  field :sign_in_count,      :type => Integer, :default => 0
  field :current_sign_in_at, :type => Time
  field :last_sign_in_at,    :type => Time
  field :current_sign_in_ip, :type => String
  field :last_sign_in_ip,    :type => String

  #Shit we added
  field :name, type: String
  field :organizer, type: Boolean, default: false
  field :points, type: Integer, default: 0

  validates :name, presence: true

  ## Confirmable
  # field :confirmation_token,   :type => String
  # field :confirmed_at,         :type => Time
  # field :confirmation_sent_at, :type => Time
  # field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  has_many :topics

  def voted_on?(topic)
    topic.voters.any? { |v| v.user_id == self._id }
  end

  def volunteered_for?(topic)
    topic.volunteers.any? { |v| v.user_id == self._id }
  end

  def vote_on!(topic)
    return false if voted_on?(topic)
    voter = topic.voters.new(user_id: _id)
    voter.save
  end

  def volunteer_for!(topic)
    return false if volunteered_for?(topic)
    topic.volunteers.build(user_id: _id)
    topic.save
  end

  def earn_points!(earned)
    puts earned.class.name
    self.points += earned
    save
    earned
  end

  def self.by_points
    self.all.sort_by { |t| t.points }.reverse
  end

end
