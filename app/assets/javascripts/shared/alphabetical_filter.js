function AlphabeticalSlider(slider, letter_view, target_list){
  var _this = this;
  this.slider = slider; // Ref to the input range element
  this.letter_view = letter_view; // Ref to the element, whose HTML refers to the value of the input range
  this.target_list = target_list; // The target list to be filtered

  var event = isIE() ? "change" : "input";

  this.slider.on(event, function() {
    _this.filter();
  });
}

// Converts the input slider to a letter, updates the view and results
AlphabeticalSlider.prototype.filter = function(){
  var _this = this;
  var letter = String.fromCharCode(parseInt(_this.slider.val()) + 64);
  _this.updateCurrentLetter(letter);
  _this.filterResults(letter);
}

// Updates the letter view with the newLetter value
AlphabeticalSlider.prototype.updateCurrentLetter = function(newLetter){
  var _this = this;
  _this.letter_view.html(newLetter);
}

// Resets and filters the results based on the class, which refers to the starting letter on each item
AlphabeticalSlider.prototype.filterResults = function(letter){
  var _this = this;

  // Reset display
  _this.target_list.find(".no-results-msg").hide();
  _this.target_list.find(".item").hide();
  // Filter
  var filterResults = _this.target_list.find("."+letter);
  // Update display
  if(filterResults.length == 0)
    _this.target_list.find(".no-results-msg").show();
  else
    filterResults.show();
}

// Resets the filter and the filter ui
AlphabeticalSlider.prototype.resetFilter = function(){
  var _this = this;
  _this.target_list.find(".item").show();
  _this.slider.val(1);
  _this.letter_view.html('A');
}

AlphabeticalSlider.prototype.moveToLetter = function(letter){
  var _this = this;

  var charCode = letter.charCodeAt(0);
  _this.slider.val(charCode - 64);
  _this.updateCurrentLetter(letter);
  _this.filterResults(letter);
}
