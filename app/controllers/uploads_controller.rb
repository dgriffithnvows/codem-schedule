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
    # This is now handled in app/views/uploads/create.js.erb
#    if @upload.save
#      flash[:notice] = "Successfully created webinar"
#      redirect_to uploads_path
#    else
#      flash[:notice] = "Could not create webinar"
#      render :action => 'new'
#    end
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
  def destroy
    @upload = Upload.find(params[:id])
    if @upload.destroy
      flash[:notice] = "Successfully deleted webinar"
      redirect_to uploads_path
    else
      flash[:notice] = "Could not delete webinar"
    end
  end
end
