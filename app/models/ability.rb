# frozen_string_literal: true

class Ability
  include CanCan::Ability
    def initialize(user)
    can :access, :rails_admin       
    can :manage, :dashboard
    if user.role.to_s == "super_admin"
        puts "i am in super_admin"
        can :read, :all
         can :update, :all
         can :create, :all
         can :destroy, :all
         can :post_action, Post
    elsif user.role.to_s == "proof_reader"
        puts "i am in proof_loader"
        can :read, Post
        can :read_action, Post
        can :invitation_action, Post
        can :invite_action, Admin
        can :accept_action, Post
        can :proofreading_action, Admin
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
