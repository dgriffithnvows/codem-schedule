# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery -> 
  datasToSubmit = {}  #datasToSubmit (very poorly names) holds
                             #  submit:         function - tells jQuery-fileupload to submit the file to the server
  $.getScript "/assets/jquery-fileupload/vendor/jquery.ui.widget.js", () -> #These three lines should be removed in production because the asset pipeline combines the js files and they execute in the right order see: https://github.com/tors/jquery-fileupload-rails/issues/58
    $.getScript "/assets/jquery-fileupload/jquery.iframe-transport.js", () ->
      $.getScript "/assets/jquery-fileupload/jquery.fileupload.js", () ->
        uploadName = ''
        uploadExtension = null
        $("#upload_video")
        .fileupload
          dataType: "script"
          add: (e, data) ->
            file = data.files[0]
            fileName = (file.name).replace(/\ /g, "_")
            uploadName = ($("#upload_name").val()).replace(/\ /g, "_")
            types = /(\.|\/)(mts|mp4)$/i
            if types.test(file.type) || types.test(file.name)
              if uploadExtension == null
                uploadExtension=(file.name).match(types)[0]
              if uploadExtension != (file.name).match(types)[0]
                alert "The uploaded files must be the same type of file."
                return false
              data.context = $(tmpl("template-upload", file))
              $('#progressContainer').append(data.context)
              datasToSubmit[fileName.toString()+"_of_"+uploadName] = {}
              datasToSubmit[fileName.toString()+"_of_"+uploadName] =
                submit: data 
                reconsturcted: false
                combined: false
            else
              alert ""+fileName+" has an unexpected file format. Please choose only MTS and MP4 files."
          progress: (e, data) ->
            if data.context
              progress = parseInt(data.loaded / data.total * 100, 10)
              data.context.find('.bar').css('width', progress + '%')
          maxChunkSize: 10000000
          done: (e, data) ->
            name = (data.files[0].name).replace(/\ /g, "_")
            uploadName = ($("#upload_name").val()).replace(/\ /g, "_")
            reconstruct name, uploadName, Object.keys(datasToSubmit).length
        #  formData (form) ->
#          start: (e) ->
#            console.log Object.keys e
#            console.log e.target
#          chunksend: (e, data) ->
#            console.log "chunk"

#          autoUpload: false #This will prevent the upload until you call it to upload
#          dropZone: "string" #The description is kina vague but this is how you change the dropzone(probably selector). the default is the entire document
#          fileInput: #set to null to disable the change listener
        $("#submitUploads").click ->
          if Object.keys(datasToSubmit).length > 0 ####This is wrong #######
            $(this).parents("form").hide()
            pubnub = PUBNUB.init
              subscribe_key: "sub-c-6f382e90-804e-11e2-b64e-12313f022c90"
            console.log "PUBNUB: subscribed to `codem_upload_"+uploadName+"`"
            pubnub.subscribe
              channel: "codem_upload_"+uploadName
              message: (m) ->
                console.log(m)
            $.each datasToSubmit, (index, value) ->
              value["submit"].submit()
            false
          else
            alert "You must first select a file."
            false
        reconstruct = (fileName, uploadName, numFiles)  -> # send file 1 of 12 etc
          $.ajax
            type: "POST"
            url: "/uploads/reconstruct"
            data:
              fileName: fileName
              uploadName: uploadName
              numberOfFiles: numFiles
            dataType: "json"
            success: (data, status, bar) -> 
              console.log "data | status | bar"
              console.log data
              console.log status
              console.log bar
                                            
                                            
                                            
                                            
                                            
