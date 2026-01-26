async function playAndLog(u_no, m_no) {
    // 1. 위치 정보(GPS) 가져오기
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(async (position) => {
            const lat = position.coords.latitude;
            const lon = position.coords.longitude;
            const apiKey = '9021ce9b1f7a9ae39654c4cb2f33250a'; // 발급받은 키 입력

            // 2. 날씨 정보 가져오기
            const weatherUrl = `https://api.openweathermap.org/data/2.5/weather?lat=${lat}&lon=${lon}&appid=${apiKey}`;
            
            try {
                const response = await fetch(weatherUrl);
                const weatherData = await response.json();
                
                // 날씨 코드 (예: 800=Clear, 500=Rain 등)
                const weatherCode = weatherData.weather[0].id;

                // 3. 백엔드로 로그 전송
                const logData = {
                    u_no: u_no,
                    m_no: m_no,
                    h_location: Math.floor(lat), // 간단하게 위도 앞자리만 코드로 사용 (정수형)
                    h_weather: weatherCode       // 날씨 코드 저장
                };

                sendPlayLog(logData);

            } catch (error) {
                console.error("날씨 정보 획득 실패", error);
            }
        });
    }
}

function sendPlayLog(logData) {
    fetch('/api/music/play', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(logData)
    })
    .then(res => res.text())
    .then(data => console.log("로그 저장 완료:", data));
}