Polymer({
  is: 'hbs-footer',
    ready: function() {
      var today = new Date();
      this.year = today.getFullYear();
    }
});