class User < ActiveRecord::Base
  include ActiveModel::Validations

  # Validator(s)
  class OrganizationTypeValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      record.errors.add attribute, "agency org must be of correct type" if !record.agency.nil? and
        !record.agency.agency?
      record.errors.add attribute, "provider org must be of correct type" if !record.provider.nil? and
        !record.provider.provider?
    end
  end

  # enable roles for this model
  rolify
  
  # devise configuration
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Needed to Rate Trips
  ajaxful_rater

  # Updatable attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :first_name, :last_name, :prefix, :suffix, :nickname

  # Associations
  has_many :places, :conditions => ['active = ?', true] # 0 or more places, only active places are available
  has_many :trips                   # 0 or more trips
  has_many :trip_places, :through => :trips
  has_one  :user_profile            # 1 user profile
  has_many :user_mode_preferences   # 0 or more user mode preferences
  has_many :user_roles
  has_many :roles, :through => :user_roles # one or more user roles
  has_many :trip_parts, :through => :trips
  # relationships
  has_many :delegate_relationships, :class_name => 'UserRelationship', :foreign_key => :user_id
  has_many :traveler_relationships, :class_name => 'UserRelationship', :foreign_key => :delegate_id
  has_many :confirmed_traveler_relationships, :class_name => 'UserRelationship', :foreign_key => :delegate_id
  has_many :delegates, :class_name => 'User', :through => :delegate_relationships
  has_many :travelers, :class_name => 'User', :through => :traveler_relationships
  has_many :confirmed_travelers, :class_name => 'User', :through => :confirmed_traveler_relationships

  has_many :buddy_relationships, class_name: 'UserRelationship', foreign_key: :user_id
  has_many :buddies, class_name: 'User', through: :buddy_relationships, source: :delegate

  belongs_to :agency, class_name: 'Organization'
  belongs_to :provider, class_name: 'Organization'

  scope :confirmed, where('relationship_status_id = ?', RelationshipStatus::CONFIRMED)

  # Validations
  validates :email, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :agency, organization_type: true
  validates :provider, organization_type: true

  before_create :make_user_profile

  def make_user_profile
    create_user_profile
  end

  def to_s
    name
  end
    
  def name
    elems = []
    elems << prefix unless prefix.blank?
    elems << first_name unless first_name.blank?
    elems << last_name unless last_name.blank?
    elems << suffix unless suffix.blank?
    elems.compact.join(' ')
  end

  def welcome
    return nickname unless nickname.blank?
    return first_name unless first_name.blank?
    email
  end

  def has_disability?
    disabled = TravelerCharacteristic.find_by_code('disabled')
    disability_status = self.user_profile.user_traveler_characteristics_maps.where(characteristic_id: disabled.id)
    disability_status.count > 0 and disability_status.first.value == 'true'
  end

  def home
    self.places.find_by_home(true)
  end

  def clear_home
    old_homes = self.places.where(home: true)
    old_homes.each do |old_home|
      old_home.home = false
      old_home.save()
    end
  end

end
