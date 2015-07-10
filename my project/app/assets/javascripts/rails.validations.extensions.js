$(function(){
  clientSideValidations.callbacks.element.fail = function(element, message, callback) {
    callback();
    element.data('was-invalid', true)
    if (element.data('valid') !== false) {
      if(element.data('fade-error')) {
        element.closest('.input').find('.error').hide().fadeIn(400);
      } else {
        element.closest('.input').find('.error').hide().show('slide', {direction: "up"}, 500);
      }
      
    }
  }

  clientSideValidations.callbacks.element.pass = function(element, callback) {
    if(element.data('fade-error')) {
      element.closest('.input').find('.error').fadeOut(100, callback);
    } else {
      element.closest('.input').find('.error').hide('slide', {direction: "up"}, 200, callback);
    }
  }
  
  clientSideValidations.callbacks.form.fail = function(form) {
    var settings = window[form.attr('id')];
    var errorMsgs = form.find(settings.error_tag + '.' + settings.error_class);
    var allOutOfOview = true;
    errorMsgs.each(function(){
      if(isInView(this)) {
        allOutOfOview = false;
        return false;
      }
      
    })
    if(!allOutOfOview) return;
    var scrollTo = errorMsgs.eq(0).closest(settings.wrapper_tag).offset().top;
    $(document).scrollTop(scrollTo);
  }
  
  var initCustomHandlers = function(){
    $('form[data-validate]').each(function(){
      var $this = $(this);
      var settings = window[$this.attr('id')];

      $this.find('select[data-validate]').live('change', function(){
        $(this).isValid(settings.validators);
      });

      $this.find('[data-validate]:input').live('keyup click change', function() {
        var $this = $(this);
        if($this.data('was-invalid')) {
          $this.data('changed', true);
          $this.isValid(settings.validators);
        }
      }).each(function(){
        var $this = $(this);
        if($this.parent().find('.error').length) {
          $this.data('was-invalid', true)
        }
      })
    
    
      //copy of events handlers for original for radio
      var addError = function(element, message) {
        clientSideValidations.formBuilders[settings.type].add(element, settings, message);
      }
      var removeError = function(element) {
        clientSideValidations.formBuilders[settings.type].remove(element, settings);
      }
      $this.find('[data-validate]:input:radio')
      .live('focusout', function() {
          var $this = $(this);
          //validate all inputs with the same name
          $this.closest('form').find('input:radio[name=' + $this.attr('name') + ']').each(function(){
            $(this).isValid(settings.validators);
          });
        })
      .live('change', function() {$(this).closest('form').find('input:radio[name=' + $(this).attr('name') + ']').data('changed', true);})
      // Callbacks
      .live('element:validate:after', function(eventData) {clientSideValidations.callbacks.element.after( $(this), eventData);})
      .live('element:validate:before', function(eventData) {clientSideValidations.callbacks.element.before($(this), eventData);})
      .live('element:validate:fail', function(eventData, message) {
        var element = $(this);
        clientSideValidations.callbacks.element.fail(element, message, function() {
          addError(element, message);
        }, eventData)})
      .live('element:validate:pass', function(eventData) {
        var element = $(this);
        clientSideValidations.callbacks.element.pass(element, function() {
          removeError(element);
        }, eventData)})
    });
  }
  
  initCustomHandlers();
  
  initFormValidations = function(form) {
    $(form).validate();
    initCustomHandlers();
  }
  
  clientSideValidations.formBuilders['SimpleForm::FormBuilder'].add = function(element, settings, message) {
      var wrapper = element.closest(settings.wrapper_tag);
      wrapper.addClass(settings.wrapper_error_class);
      var errorElement = element.closest(settings.wrapper_tag).find(settings.error_tag + '.' + settings.error_class)
      if(errorElement.length) {
        errorElement.text(message);
        errorElement.show();
        return;
      }
      errorElement = $('<' + settings.error_tag + ' class="' + settings.error_class + '">' + message + '</' + settings.error_tag + '>');
      wrapper.append(errorElement);
  }
  
  clientSideValidations.validators.local['greather_or_equal_to_other_attr'] = function(el, options) {
    var objName = el.attr('name').match(/^[^[]+/)[0]
    var otherVal = parseInt($('[name="' + objName + '[' + options.other_attr + ']"]').val())
    if(parseInt(el.val()) < otherVal) {
      return options.message.replace(options.other_attr, otherVal);
    }
  }
  clientSideValidations.validators.local['less_or_equal_to_other_attr'] = function(el, options) {
    var objName = el.attr('name').match(/^[^[]+/)[0]
    var otherVal = parseInt($('[name="' + objName + '[' + options.other_attr + ']"]').val())
    if(parseInt(el.val()) > otherVal) {
      return options.message.replace(options.other_attr, otherVal);
    }
  }
  var superLocalPresence = clientSideValidations.validators.local.presence;
  
  clientSideValidations.validators.local.presence = function(el, options) {
    if(el.is(':radio')) {
      var val = el.closest('form').find('input:radio[name=' + el.attr('name') + ']:checked').val();
      if (/^\s*$/.test(val || "")) {
        return options.message;
      } 
    } else {
      return superLocalPresence.apply(this, arguments);
    }
  }
  
  var superLocalNumericality = clientSideValidations.validators.local.numericality;
  
  clientSideValidations.validators.local.numericality = function(el, options) {
    if (/^\s*$/.test(el.val() || "")) {
      return;
    } else {
      return superLocalNumericality.apply(this, arguments);
    }
  }
  
  var superLocalFormat = clientSideValidations.validators.local.format;
  
  clientSideValidations.validators.local.format = function(el, options) {
    if (/^\s*$/.test(el.val() || "")) {
      return;
    } else {
      return superLocalFormat.apply(this, arguments);
    }
  }
})