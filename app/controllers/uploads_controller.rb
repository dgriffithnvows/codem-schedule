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
    
    uploadDir = Rails.root.join("public", "uploads")
    pid = spawn("ruby #{Rails.root.join('app','workers', 'reconstructUploadsAndSubmitJob.rb')} #{uploadDir} #{params[:fileName]} #{params[:uploadName]}")
    Process.detach(pid)

    respond_to do |format|
      format.any {render :json => {:respons => "reconstructing codem_reconstruct_#{params[:fileName]}_of_#{params[:uploadName]}"}}
    end
  end
#  def prepareFileForCodem                                            #This is where we need to start tomorrow. We have just finished pubnub publishing the reconstruct message back to the page
#    mtsParts = Dir[File.join(newDir, "*.MTS")].sort
#    if mtsParts.any?
#      File.open(File.join(newDir, fileName), "w") do |f|
#        mtsParts.each do |part|
#          f.write(File.read(part))
#          File.delete(part)
#        end
#      end
#    end
#  end
end
