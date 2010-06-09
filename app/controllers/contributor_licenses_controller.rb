class ContributorLicensesController < ApplicationController
  unloadable
  
  def show
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
      render :action => 'show'
    end
  end

  def upload
    @contributor_license = ContributorLicense.new
  end
  
end
