Polymer({
  is: 'hbs-container',
  properties: {
    querySmall: {
      type: String,
      value: '(max-width:544px)'
    },
    queryMedium: {
      type: String,
      value: '(max-width:768px)'
    }
  }
});