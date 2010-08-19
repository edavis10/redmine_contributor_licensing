class ContributorLicensesController < InheritedResources::Base
  unloadable

  respond_to :html

  before_filter :require_admin, :except => [:sign, :create, :upload]
  before_filter :assign_new_object, :only => [:sign, :upload]
  before_filter :assign_license_content, :only => [:sign, :create]

  def index
    index! do |format|
      format.html { render :layout => !request.xhr?	 }
    end
  end
  
  def sign
  end

  def create
    @contributor_license = user_proxy.build_contributor_license(params[:contributor_license])
    
    saved_or_accepted = if params[:clickwrap]
                          @contributor_license.accept!
                        else
                          @contributor_license.save
                          Attachment.attach_files(@contributor_license, params[:attachments])
                        end
    
    if saved_or_accepted
      if @contributor_license.accepted?
        flash[:notice] = l(:contributor_license_text_accepted)
      else
        flash[:notice] = l(:contributor_license_text_pending)
      end
      if user_proxy == User.current
        redirect_to root_path
      else # Admins
        redirect_to contributor_licenses_path
      end
    else
      render :action => 'sign'
    end
  end

  def upload
  end

  def approve
    @contributor_license = ContributorLicense.find(params[:id])
    if @contributor_license
      @contributor_license.acceptance = 'I agree by admin'
      @contributor_license.accept!
      flash[:notice] = l(:contributor_license_text_accepted)
    end
    redirect_to contributor_licenses_path
  end

  def destroy
    destroy! do |success, failure|
      success.html {
        flash.replace(:notice => l(:contributor_licensing_successful_delete))
        redirect_to contributor_licenses_path
      }
      
      failure.html {
        flash.replace(:error => l(:contributor_licensing_error_can_not_delete_accepted))
        redirect_to contributor_licenses_path
      }
    end
  end

  protected
  def collection
    @state = params[:state] || 'accepted'

    @user_count = User.active.with_contributor_license_of(@state).count
    @user_pages = Paginator.new(self, @user_count, per_page_option, params['page'])
    @users = User.active.with_contributor_license_of(@state).all(:limit => @user_pages.items_per_page, :offset => @user_pages.current.offset)
  end

  def assign_new_object
    @contributor_license = ContributorLicense.new
  end

  def assign_license_content
    @content = Setting.plugin_redmine_contributor_licensing['content']
  end

  # A simple proxy to the current user or paramaterized user (admins only)
  def user_proxy
    if User.current.admin? && params[:contributor_license].present? && params[:contributor_license][:user_id].present?
      User.find(params[:contributor_license][:user_id])
    else
      User.current
    end
  end
end
