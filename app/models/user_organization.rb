class UserOrganization < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  has_many :clubs, through: :organization
  has_many :activities, as: :trackable, dependent: :destroy

  enum status: {pending: 0, joined: 1, reject: 2}

  scope :are_admin, ->{where is_admin: true}
  scope :are_member, ->{where is_admin: false}
  scope :without_user_ids, ->user_ids{where.not user_id: user_ids}
  scope :newest, ->{order created_at: :desc}
  scope :load_user_organization, ->organization_id{where organization_id: organization_id}
  scope :except_me, ->(user_id){where "user_id != ?", user_id}
  scope :by_user_ids, ->user_ids{where user_id: user_ids}

  delegate :full_name, :avatar, :email, :phone, to: :user, prefix: :user, allow_nil: :true
  delegate :name, :description, :phone, :email, :logo, to: :organization, allow_nil: :true

  after_destroy :leave_club_in_organization

  class << self
    def join? organization
      find_by(organization_id: organization.id).nil?
    end

    def verify_manager? user
      user = find_by(id: user.id)
      return user.is_admin if user
      false
    end

    def create_user_organization user_id, organization_id
      create user_id: user_id, organization_id: organization_id,
        status: :joined
    end

    def find_with_user_of_company user_id, organization_id
      find_by user_id: user_id, organization_id: organization_id
    end

    def user_not_joined user_clubs
      self.without_user_ids user_clubs
    end

    def load_user user_id
      find_by id: user_id
    end
  end

  def leave_club_in_organization
    club_ids = self.organization.clubs.ids
    user_clubs = UserClub.by_user_id_and_club_ids self.user_id, club_ids
    user_clubs.destroy_all if user_clubs.present?
  end
end
