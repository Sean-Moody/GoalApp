class User < ApplicationRecord
    #before_validation :ensure_session_token
    after_initialize :ensure_session_token
    
    validates :username, :password_digest, :session_token, presence: true 
    validates :username, :session_token, uniqueness: true 
    validates :password, length: { minimum: 6 }, allow_nil: true 

    has_many :goals

    attr_reader :password 

    def password=(password)
        @password = password 
        self.password_digest = BCrypt::Password.create(password)
    end 

    def is_same_password?(password)
        password_object = BCrypt::Password.new(self.password_digest)
        password_object.is_password?(password)
    end

    def self.find_by_credentials(username, password)
        user = User.find_by(username: username)

        if user && user.is_same_password?(password)
            user 
        else 
            nil 
        end
    end 

    def ensure_session_token
      self.session_token||= generate_unique_session_token  
    end

    def reset_session_token
        self.session_token = generate_unique_session_token
        self.save!
        self.session_token 
    end

    def generate_unique_session_token
        session_token = SecureRandom::urlsafe_base64

        while User.exists?(session_token: session_token)
            session_token = SecureRandom::urlsafe_base64
        end 
        session_token 
    end 



end
