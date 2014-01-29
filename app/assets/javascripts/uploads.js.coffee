# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery -> 
  window.datasToSubmit = []
  $.getScript "/assets/jquery-fileupload/vendor/jquery.ui.widget.js", () -> #These three lines should be removed in production because the asset pipeline combines the js files and they execute in the right order see: https://github.com/tors/jquery-fileupload-rails/issues/58
    $.getScript "/assets/jquery-fileupload/jquery.iframe-transport.js", () ->
      $.getScript "/assets/jquery-fileupload/jquery.fileupload.js", () ->
        $("#upload_video")
        .fileupload
          dataType: "script"
          add: (e, data) ->
        #    types = /(\.|\/)(gif|jpe?g|png)$/i
            file = data.files[0]
        #    if types.test(file.type) || types.test(file.name)
            data.context = $(tmpl("template-upload", file))
            $('#progressContainer').append(data.context)
            window.datasToSubmit.push data
#            data.submit()
        #    else
        #      alert("#{file.name} is not a gif, jpeg, or png image file")
          progress: (e, data) ->
            if data.context
              progress = parseInt(data.loaded / data.total * 100, 10)
              data.context.find('.bar').css('width', progress + '%')
          maxChunkSize: 10000000
          done: (e, data) ->
            console.log "here"
            console.log data
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
          if window.datasToSubmit.length > 0
            $(this).parents("form").hide()
            $.each window.datasToSubmit, (index, value) ->
              console.log value
              value.submit()
            false
          else
            alert "You must first select a file."
