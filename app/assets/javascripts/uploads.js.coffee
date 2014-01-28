# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery -> 
  $.getScript "/assets/jquery-fileupload/vendor/jquery.ui.widget.js", () -> #These three lines should be removed in production because the asset pipeline combines the js files and they execute in the right order see: https://github.com/tors/jquery-fileupload-rails/issues/58
    $.getScript "/assets/jquery-fileupload/jquery.iframe-transport.js", () ->
      $.getScript "/assets/jquery-fileupload/jquery.fileupload.js", () ->
        $("#upload_video").fileupload
          dataType: "script"
          add: (e, data) ->
#            types = /(\.|\/)(gif|jpe?g|png)$/i
            file = data.files[0]
#            if types.test(file.type) || types.test(file.name)
            data.context = $(tmpl("template-upload", file))
            $('#new_upload').append(data.context)
            data.submit()
#            else
#              alert("#{file.name} is not a gif, jpeg, or png image file")
          progress: (e, data) ->
            if data.context
              progress = parseInt(data.loaded / data.total * 100, 10)
              data.context.find('.bar').css('width', progress + '%')
