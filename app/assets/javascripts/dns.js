function getPassword(el){
  password = prompt("Give me your password");
  el.href = el.href + "&password=" + password;
}
