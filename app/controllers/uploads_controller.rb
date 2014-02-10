class UploadsController < ApplicationController
  def index 
    @uploads = Upload.all
  end
  def show 

    @uploads = Upload.all
    render :action => 'index'
  end
  def new
    @upload = Upload.new()
  end
  def create
    @upload = Upload.create(params[:upload]) 
    respond_to do |format|
      if @upload.save
        format.html { redirect_to uploads_path, :notice => "File successfully uploaded" }
        format.js {} # renders create.js.erb
      else
        format.html { render :action => 'new', :notice => "Could NOT upload file" }
        format.js { render :action => 'new', :notice => "Could NOT upload file" }
      end
    end
  end
  def edit
    @upload = Upload.find(params[:id])
  end
  def update
    @upload = Upload.find(params[:id])
    if @upload.update_attributes(params[:upload])
      flash[:notice] = "Successfully updates upload"
      redirect_to upload_path
    else
      render :action => 'edit'
    end
  end

  def deleteAll   #this should be replaced with database management in code
    if Upload.destroy_all()
      flash[:notice] = "Delete all uploads"
      redirect_to uploads_path
    else
      flash[:notice] = "Couldn't delete all aksdjfkj kjdsfkjasdkjfkjasdf"
    end
  end

  def destroy
    @upload = Upload.find(params[:id])
    if @upload.destroy
      flash[:notice] = "Successfully deleted uplaod"
      redirect_to uploads_path
    else
      flash[:notice] = "Could not delete upload"
    end
  end
  def reconstruct
    pid = spawn("ruby #{Rails.root.join('app','workers', 'reconstructUploadsAndSubmitJob.rb')} #{Rails.root.to_s} #{params[:fileName]} #{params[:uploadName]} #{params[:numberOfFiles]}")
    Process.detach(pid)

    respond_to do |format|
      format.any {render :json => {:status => "0", :statusDescription => "reconstructing codem_reconstruct_#{params[:fileName]}_of_#{params[:uploadName]}"}}
    end
  end
end
