function validateAll() {
    /* 1. 아이디/이메일 검사 (회원가입 uId, 로그인 modalId, 비번찾기 resetEmail 공통) */
    const emailField = $('#uId, #modalId, #resetEmail').filter(':visible').first();
    if (emailField.length > 0) {
        const email = emailField.val().trim();
        const emailReg = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
        
        if (email === "") {
            alert("이메일을 입력해주세요.");
            emailField.focus();
            return false;
        }
        if (!emailReg.test(email)) {
            alert("올바른 이메일 형식을 입력해주세요.");
            emailField.focus();
            return false;
        }
    }

    /* 2. 비밀번호 검사 (요소가 화면에 '보이고 있을 때만' 실행) */
    const pwField = $('#uPassword, #modalPw').filter(':visible').first();
    if (pwField.length > 0) {
        const password = pwField.val();
        if (password === "") {
            alert("비밀번호를 입력해주세요.");
            pwField.focus();
            return false;
        }
        if (password.length < 8 || password.length > 20) {
            alert("비밀번호는 8~20자로 입력해주세요.");
            pwField.focus();
            return false;
        }
    }

    /* 3. 검색어 검사 (헤더 검색창이 있을 때만) */
    const searchField = $('#headerSearchKeyword');
    if (searchField.length > 0 && searchField.is(':focus')) { // 검색 버튼 클릭 시나 포커스 시만
        const search = searchField.val().trim();
        if (search === "") {
            alert("검색어를 입력해주세요.");
            searchField.focus();
            return false;
        }
    }

	/* 4. 기타 정보 (닉네임, 지역 등 - 요소가 존재할 때만) */
	    const nickField = $('#uNick').filter(':visible');
	    if (nickField.length > 0 && nickField.val().trim() !== "") {
	        if (nickField.val().length < 2 || nickField.val().length > 20) {
	            alert("닉네임은 2~20자로 입력해주세요.");
	            nickField.focus();
	            return false;
	        }
	    }

    const region = $('input[name="uRegion"]').val();

    if (region !== undefined && region.length > 20) {
        alert("지역은 최대 20자까지 입력 가능합니다.");
        $('input[name="uRegion"]').focus();
        return false;
    }

    const genre = $('input[name="uPreferredGenre"]').val();

    if (genre !== undefined && genre.length > 20) {
        alert("선호 장르는 최대 20자까지 입력 가능합니다.");
        $('input[name="uPreferredGenre"]').focus();
        return false;
    }

    return true;
}