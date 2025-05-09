class Checkvalidate {
  String? validateId(String? id, bool? idValid) {
    String pattern = r'^[a-zA-Z0-9]{6,12}$';
    RegExp regExp = RegExp(pattern);
    if (id == null || id.isEmpty) {
      return "아이디를 입력해주세요.";
    } else if (id.length < 6) {
      return "6자리 이상 입력해주세요.";
    } else if (id.length > 12) {
      return "12자리 이하로 입력해주세요.";
    } else if (!regExp.hasMatch(id)) {
      return "영문 6글자 이상 12자 이하로 입력해주세요.";
    } else {
      if (idValid == false) {
        return "중복확인을 해주세요.";
      } else {
        return null;
      }
    }
  }

  bool checkIdInput(String id) {
    String pattern = r'^[a-zA-Z0-9]{6,12}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(id); // true이면 유효한 아이디, false이면 비유효한 아이디
  }

  String? validatePassword(String? password) {
    String pattern = r'^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[$`~!@$!%*#^?&\\(\\)\-_=+]).{8,15}$';
    RegExp regExp = RegExp(pattern);
    if (password == null || password.isEmpty) {
      return "비밀번호를 입력해주세요.";
    } else if (password.length < 8) {
      return "8자리 이상 입력해주세요.";
    } else if (password.length > 15) {
      return "15자리 이하로 입력해주세요.";
    } else if (!regExp.hasMatch(password)) {
      return "특수문자, 문자, 숫자 포함 8자 이상 15자 이하로 입력해주세요.";
    } else {
      return null;
    }
  }

  String? validateRePassword(String password, String? rePassword) {
    if (rePassword == null || rePassword.isEmpty) {
      return "비밀번호 확인을 입력해주세요.";
    } else if (password != rePassword) {
      return "입력한 비밀번호가 다릅니다.";
    } else {
      return null;
    }
  }

  String? validateNickName(String? nickName, bool? nickNameValid) {
    String pattern = r'^[^\s](\S*(\s\S+)*)?$';
    RegExp regExp = RegExp(pattern);
    if (nickName == null || nickName.isEmpty) {
      return "닉네임을 입력해주세요.";
    } else if (!regExp.hasMatch(nickName)) {
      return "앞/뒤 공백 없이 한 글자 이상 입력해주세요.";
    } else if (nickName.length > 12) {
      return "12자리 이하로 입력해주세요.";
    } 
    else {
      if (nickNameValid == false) {
        return "중복확인을 해주세요.";
      } else {
        return null;
      }
    }
  }

  bool checkNickNameInput(String nickName) {
    String pattern = r'^(?!\s*$).{1,12}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(nickName); // true이면 유효한 닉네임, false이면 비유효한 닉네임
  }
}