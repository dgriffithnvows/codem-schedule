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
    fileName = params[:fileName].tr(" ", "_")
    uploadName = params[:uploadName]
    uploadDir = Rails.root.join("public", "uploads")
    newDir = File.join(uploadDir, uploadName)
    Dir.mkdir(newDir) unless File.exist?(newDir)
    chunk = Dir[File.join(uploadDir, "chunks_of_#{fileName}", "chunk_*")].sort
    File.open(File.join(newDir, fileName), "w") do |f|
      chunk.each do |chunk| 
        f.write(File.read(chunk))
        File.delete(chunk)
      end
    end
    Dir.delete(File.join(uploadDir, "chunks_of_#{fileName}")) if (Dir.entries(File.join(uploadDir, "chunks_of_#{fileName}")) - %w{ . .. }).empty?
    flash[:notice] = "Reconstructed #{fileName} on server side"
    respond_to do |format|
      format.any {render :json => {:respons => "It worked!"}}
    end
  end
end
