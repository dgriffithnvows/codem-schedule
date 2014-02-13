# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery -> 
  fileUploads = {}  
  $.getScript "/assets/jquery-fileupload/vendor/jquery.ui.widget.js", () ->       #These three lines should be removed in production because the asset 
    $.getScript "/assets/jquery-fileupload/jquery.iframe-transport.js", () ->     #pipeline combines the js files and they execute in the right order
      $.getScript "/assets/jquery-fileupload/jquery.fileupload.js", () ->         #see: https://github.com/tors/jquery-fileupload-rails/issues/58

        uploadName = ''
        uploadExtension = null

        $("#upload_video")
        .fileupload
          dataType: "script"
          add: (e, data) ->
            file = data.files[0]
            fileName = (file.name).replace(/\ /g, "_")
            types = /(\.|\/)(mts|mp4)$/i
            if types.test(file.type) || types.test(file.name)
              if uploadExtension == null
                uploadExtension=(file.name).match(types)[0]
              if uploadExtension != (file.name).match(types)[0]
                alert "The uploaded files must be the same type of file."
                return false
              data.context = $(tmpl("template-upload", file))
              $('#progressContainer').append(data.context)
              fileUploads[fileName.toString()] = data 
            else
              alert ""+fileName+" has an unexpected file format. Please choose only MTS and MP4 files."
          progress: (e, data) ->
            if data.context
              progress = parseInt(data.loaded / data.total * 100, 10)
              data.context.find('.bar').css('width', progress + '%')
          maxChunkSize: 15000000
          done: (e, data) ->
            name = (data.files[0].name).replace(/\ /g, "_")
            reconstruct name, uploadName, Object.keys(fileUploads).length
        #  formData (form) ->
#          start: (e) ->
#            console.log Object.keys e
#            console.log e.target
#          chunksend: (e, data) ->
#            console.log "chunk"

#          dropZone: "string" #The description is kina vague but this is how you change the dropzone(probably selector). the default is the entire document
#          fileInput: #set to null to disable the change listener
        $("#submitUploads").click (e) ->
          e.preventDefault()
          specialChars = ($("#upload_name").val()).match(/[^a-zA-Z0-9- _]+/g)
          if specialChars!=null 
            alert "Your input must contain only Letters, Numbers, Underscores(_), and hyphens(-)."
          else if ($("#upload_name").val()) == ''
            alert "Please name this upload"
          else if Object.keys(fileUploads).length > 0
            uploadName = ($("#upload_name").val()).replace(/\ /g, "_")
            $(this).parents("form").hide()
            pubnub = PUBNUB.init
              subscribe_key: "sub-c-6f382e90-804e-11e2-b64e-12313f022c90"
            console.log "PUBNUB: subscribed to `codem_upload_"+uploadName+"`"
            pubnub.subscribe
              channel: "codem_upload_"+uploadName
              message: (m) ->
                console.log(m.log)
            $.each fileUploads, (i, data) ->
              data.submit()
          else
            alert "You must first select a file."

        reconstruct = (fileName, uploadName, numFiles)  -> 
          $.ajax
            type: "POST"
            url: "/uploads/reconstruct"
            data:
              fileName: fileName
              uploadName: uploadName
              numberOfFiles: numFiles
            dataType: "json"
            success: (data, status, bar) -> 
              console.log "Preparing to reconstruct "+fileName
