require "nested_form/engine"
require "nested_form/builder_mixin"
require Rails.root.join('lib', 'rails_admin', 'post_action.rb')
require Rails.root.join('lib', 'rails_admin', 'invitation_action.rb')
require Rails.root.join('lib', 'rails_admin', 'read_action.rb')
require Rails.root.join('lib', 'rails_admin', 'invite_action.rb')
require Rails.root.join('lib', 'rails_admin', 'accept_action.rb')

RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
  warden.authenticate! scope: :admin
   end
   config.current_user_method(&:current_admin)

  ## == CancanCan ==
  config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    post_action do
    visible do
        bindings[:abstract_model].model.to_s == "Post"
      end
    end 
    invitation_action do
    visible do
        bindings[:abstract_model].model.to_s == "Post"
      end
    end 
    read_action do
    visible do
        bindings[:abstract_model].model.to_s == "Post"
      end
    end
    accept_action do
    visible do
        bindings[:abstract_model].model.to_s == "User"
      end
    end 
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
