# frozen_string_literal: true

class User < Sequel::Model
  ## -------------------- Requirements -------------------- ##
  attr_accessor :password, :password_confirmation
  ## ----------------------- Scopes ----------------------- ##
  ## --------------------- Constants ---------------------- ##
  ## ----------------------- Enums ------------------------ ##
  ## -------------------- Associations -------------------- ##
  one_to_many :posts, on_delete: :cascade
  ## -------------------- Validations --------------------- ##
  def validate
    super
    validates_presence :password
    validates_length_range 4..40, :password
    validates_presence :password_confirmation
    errors.add(:password_confirmation, 'must confirm password') if password != password_confirmation
  end

  def before_save
    super
    encrypt_password
  end
  ## --------------------- Callbacks ---------------------- ##
  ## ------------------- Class Methods -------------------- ##
  ## ---------------------- Methods ----------------------- ##

  def self.authenticate(email, password)
    user = filter(Sequel.function(:lower, :email) => Sequel.function(:lower, email)).first
    return unless user

    user if user.has_password?(password)
  end

  def has_password?(password)
    BCrypt::Password.new(password_hash) == password
  end

  private

  def encrypt_password
    self.password_hash = BCrypt::Password.create(password)
  end
end
