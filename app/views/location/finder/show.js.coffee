address = jQuery.parseJSON('<%= raw @address %>')
postal_code_id = '#<%= params[:postal_code_id] %>'
prefix = postal_code_id.replace /postal_code$/, ''

for attr, value of address
  $("#{prefix}#{attr}").val(value) if value
