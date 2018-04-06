class Ability
  include CanCan::Ability

  def initialize user, controller_namespace
    case controller_namespace
    when Settings.namespace_admin
      can :manage, User
    when Settings.namespace_club_manage
      can :manage, StatisticReport do |report|
        report.club.user_clubs.manager.pluck(:user_id).include? user.id
      end

      can :read, StatisticReport do |report|
        report.club.user_clubs.pluck(:user_id).include? user.id
      end

      can :read, Evaluate do |evaluate|
        evaluate.club.user_clubs.manager.pluck(:user_id).include?(user.id)
      end

      can :manage, :club_budget do |club|
        club.keys.first.user_clubs.manager.pluck(:user_id).include?(user.id)
      end

      can :manage, :import_user_club do |club|
        club.keys.first.user_clubs.manager.pluck(:user_id).include?(user.id)
      end

      can :manage, :user_club do |club|
        club.keys.first.user_clubs.manager.pluck(:user_id).include?(user.id)
      end
    else
      can :is_admin, Club do |club|
        club.user_clubs.manager.map(&:user_id).include?(user.id)
      end

      can :manage, ClubType do |type|
        type.organization.user_organizations.are_admin.pluck(:user_id)
          .include?(user.id)
      end

      can :manage, [Organization] do |organization|
        organization.user_organizations.are_admin.pluck(:user_id).include? user.id
      end

      can :read, Organization

      can [:update, :read], [StatisticReport] do |statistic|
        organization = Organization.find_by id: statistic.club.organization.id
        organization.user_organizations.are_admin.pluck(:user_id)
          .include?(user.id)
      end

      can [:create, :update], [StatisticReport] do |statistic|
        club = Club.find_by id: statistic.club_id
        club.user_clubs.manager.map(&:user_id).include?(user.id)
      end

      can :manage, ReportCategory do |category|
        category.organization.user_organizations.are_admin.pluck(:user_id)
          .include?(user.id)
      end

      can :manage, OrganizationSetting do |setting|
        setting.organization.user_organizations.are_admin.pluck(:user_id)
          .include?(user.id)
      end

      can :manage, :event_notification do |club|
        club.keys.first.user_clubs.manager.pluck(:user_id).include?(user.id)
      end

      can :show, :event_notification

      can :manage, Video do |video|
        video.album.club.user_clubs.manager.pluck(:user_id).include? user.id
      end

      can :show, Post do |post|
        post.target.club.user_clubs.joined.pluck(:user_id).include? user.id
      end

      can [:edit, :update], Post do |post|
        post.user_id == user.id
      end

      can [:create], Post do |post|
        post.target.club.user_clubs.joined.pluck(:user_id).include?(user.id)
      end

      can :destroy, Post do |post|
        post.user_id == user.id || post.target.club.user_clubs.manager.pluck(:user_id).include?(user.id)
      end

      can [:create], Comment do |comment|
        comment.target.club.user_clubs.joined.pluck(:user_id).include?(user.id)
      end

      can [:update], Comment do |comment|
        post.user_id == user.id
      end

      can [:create, :destroy], UserEvent do |user_event|
        user_event.event.club.user_clubs.joined.pluck(:user_id).include?(user.id)
      end

      can [:show], Event do |event|
        event.club.user_clubs.joined.pluck(:user_id).include?(user.id) ||
          event.is_public
      end

      can [:create, :update], Event do |event|
        event.club.user_clubs.manager.pluck(:user_id).include?(user.id)
      end

      can [:destroy], Event do |event|
        event.id = user.id &&
          event.club.user_clubs.manager.pluck(:user_id).include?(user.id)
      end

      can [:show], Club

      can [:manage], Club do |club|
        club.user_clubs.manager.pluck(:user_id).include?(user.id)
      end

      can [:create], Club do |club|
        club.organization.user_organizations.are_admin.pluck(:user_id).include?(user.id)
      end

      can [:show], User do |user_load|
        (user.clubs.ids & user_load.clubs.ids).present? || user.id == user_load.id ||
          user.user_organizations.are_admin.any?
      end

      can [:edit, :update], User do |user_load|
        user.id == user_load.id
      end

      can :manage, Rule do |rule|
        rule.organization.user_organizations.are_admin.pluck(:user_id)
          .include?(user.id)
      end

      can :manage, Evaluate do |evaluate|
        evaluate.club.organization.user_organizations.are_admin.pluck(:user_id)
          .include?(user.id)
      end
    end
  end
end
