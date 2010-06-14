class ContributorLicensesController < InheritedResources::Base
  unloadable

  respond_to :html

  before_filter :require_admin, :except => [:sign, :create, :upload]
  before_filter :assign_new_object, :only => [:sign, :upload]
  before_filter :assign_license_content, :only => [:sign, :create]
  
  def sign
  end

  def create
    @contributor_license = User.current.build_contributor_license(params[:contributor_license])
    
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
      redirect_to root_path
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
    @contributor_licenses = ContributorLicense.assigned_to_users.sorted_by_login
  end

  def assign_new_object
    @contributor_license = ContributorLicense.new
  end

  def assign_license_content
    @content = Setting.plugin_redmine_contributor_licensing['content']
  end

end
