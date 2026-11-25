// HTML confirmation is also enforced by PHP using the confirmation checkbox.
document.querySelectorAll('form[data-confirm]').forEach(form=>form.addEventListener('submit',event=>{if(!window.confirm('Delete this record? This may be permanent.'))event.preventDefault();}));
