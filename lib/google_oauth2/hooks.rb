module GoogleOauth2
  class Hooks < Redmine::Hook::ViewListener

    render_on :view_account_login_bottom,
              :partial => 'login_links'

    def view_layouts_base_html_head(context)
      stylesheet_link_tag 'style', :plugin => :google_oauth2
    end
  end
end
