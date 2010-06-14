class ContributorLicensesController < InheritedResources::Base
  unloadable

  respond_to :html

  before_filter :require_admin, :except => [:sign, :create, :upload]
  
  def sign
    @contributor_license = ContributorLicense.new
    @content = Setting.plugin_redmine_contributor_licensing['content']
  end

  def create
    @content = Setting.plugin_redmine_contributor_licensing['content']

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
    @contributor_license = ContributorLicense.new
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
    @contributor_licenses = ContributorLicense.all(:conditions => ["#{ContributorLicense.table_name}.user_id IS NOT NULL"],
                                                   :order => "#{User.table_name}.login ASC",
                                                   :include => :user)
  end
  
end
