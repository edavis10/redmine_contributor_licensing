class ContributorLicensesController < ApplicationController
  unloadable
  
  def show
    @contributor_license = ContributorLicense.new
    @content = Setting.plugin_redmine_contributor_licensing['content']
  end

  def create
    @content = Setting.plugin_redmine_contributor_licensing['content']

    @contributor_license = User.current.build_contributor_license(params[:contributor_license])
    if @contributor_license.accept!
      flash[:notice] = l(:contributor_license_text_accepted)
      redirect_to root_path
    else
      render :action => 'show'
    end
  end
end
