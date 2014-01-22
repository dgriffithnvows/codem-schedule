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
    @upload = Upload.new(params[:upload])
    if @upload.save
      flash[:notice] = "Successfully created webinar"
      redirect_to uploads_path
    else
      flash[:notice] = "Could not create webinar"
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
