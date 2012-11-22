# = Presets Controller
#
# A preset represents command line options for ffmpeg sent to the Transcoder
class Api::PresetsController < Api::ApiController
  # == Returns a list of presets
  #
  # == Example:
  #   $ curl http://localhost:3000/api/presets
  #
  #   [
  #     {"preset":{
  #       "created_at":"2011-05-09T11:59:53Z",
  #       "id":1,
  #       "name":"h264",
  #       "parameters":"-acodec libfaac -ab 96k -ar 44100 -vcodec libx264 -vb 416k -vpre slow -vpre baseline -s 320x180 -y",
  #       "updated_at":"2011-05-09T11:59:53Z"}
  #     }
  #   ]
  def index
    respond_with Preset.all
  end

  # == Creates a preset
  #
  # Creates a preset using the specified parameters, which are all required. If the request was valid,
  # the created preset is returned. If the request could not be completed, a list of errors will be returned.
  #
  # === Parameters
  # Required parameters:
  # <tt>name</tt>:: Name of the preset
  # <tt>params</tt>:: Parameters to use
  #
  # Optional parameters:
  # <tt>weight</tt>:: Weight of the preset, used to distribute workload evenly
  #
  # === Response codes
  # <tt>success</tt>:: <tt>201 created</tt>
  # <tt>failed</tt>::  <tt>406 Unprocessable Entity</tt>
  #
  # === Example
  #   $ curl -d 'name=webm&parameters=params' http://localhost:3000/api/presets
  #
  #   {"preset":{
  #     "created_at":"2011-05-10T14:44:07Z",
  #     "id":3,
  #     "name":"webm",
  #     "parameters":
  #     "params",
  #     "updated_at":"2011-05-10T14:44:07Z"}
  #   }
  def create
    preset = Preset.from_api(params)
    
    if preset.valid?
      respond_with preset, :location => api_preset_url(preset) do |format|
        format.html { redirect_to presets_path }
      end
    else
      respond_with preset do |format|
        format.html { @preset = preset; render "/presets/new"}
      end
    end
  end

  # == Displays a preset
  #
  # === Parameters
  # <tt>id</tt>:: Id of the preset to display
  #
  # === Example
  #   $ curl http://localhost:3000/api/presets/1
  #
  #   {"preset":{
  #     "created_at":"2011-05-10T14:44:07Z",
  #     "id":3,
  #     "name":"webm",
  #     "parameters":
  #     "params",
  #     "updated_at":"2011-05-10T14:44:07Z"}
  #   }
  def show
    respond_with Preset.find(params[:id])
  end
  
  # == Updates a preset
  #
  # === Paramdeters
  # <tt>id</tt>:: Id of the preset to update
  # <tt>name</tt>:: Name of the preset
  # <tt>parameters</tt>:: Parameters of the preset
  # <tt>weight</tt>:: Weight of the preset
  #
  # === Example
  #
  #   $ curl -XPUT -d 'name=h264&parameters=params' http://localhost:3000/api/presets/1
  #   {} # HTTP Status: 200 OK
  def update
    if params[:preset]
      params[:name] = params[:preset][:name]
      params[:parameters] = params[:preset][:parameters]
      params[:weight]     = params[:preset][:weight]
    end

    preset = Preset.find(params[:id])

    if preset.update_attributes(:name => params[:name], :parameters => params[:parameters], :weight => params[:weight])
      respond_with preset, :location => api_preset_url(preset) do |format|
        format.html { redirect_to presets_path }
      end
    else
      respond_with preset do |format|
        format.html { @preset = preset; render "/presets/edit" }
      end
    end
  end
  
  # == Deletes a preset
  #
  # === Parameters
  # <tt>id</tt>:: Id of the preset to delete
  #
  # === Example
  #
  #   $ curl -XDELETE http://localhost:3000/api/presets/1
  #   {} # HTTP Status: 200 OK
  def destroy
    preset = Preset.find(params[:id])
    preset.destroy
    respond_with preset do |format|
      format.html { redirect_to presets_path, :notice => t('notice.deleted', :model_name => 'Preset') }
    end
  end
end
