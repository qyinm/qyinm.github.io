---
title: '[우아한 테크코스 7기 프리코스] 2주차 회고'
description: '우테코 프리코스를 하면서'
date: 2024-10-28 23:33:00 +0900
categories: [Experience, 우아한 테크코스]
tags: ['우아한 테크코스 프리코스', '회고']
related_posts:
    - woowa-precourse7-1week.md
---

## 프리코스 2주차 회고
이번 과제를 하면서 아래 사항들을 해결하고자 노력 했다.

### 1주차 피드백
- 의미없는 공백을 만들지 않는 것이 좋다. 문맥별로 공백이 있는 것이 좋다.
- 기능의 의미가 명확한 메서드 이름을 사용하자.
- 유저 입력 `readLine` 메서드는 값이 없을 시 NoSuchElementException 예외를 발생이 생김으로 예외처리를 하자

###  내가 신경 쓰고자 한 부분
- 랜덤 값 사용 기능 테스트 용이성
- 메서드 이름으로 기능을 파악할 수 있도록 하자.
- 입출력 View 레이어 분리
- OutputView 클래스에서 도메인 출력 시 포매팅 하는 것이 좋을 지

### 랜덤 값 사용 기능 테스트 용이성
2주차 과제는 레이싱 자동차가 1-6 사이 숫자를 랜덤으로 뽑은 후 4이상 시 전진하는 기능이다. 이 때 랜덤 값을 사용하는 기능이 있어 테스트 용이성을 높이기 위해 랜덤 값을 사용하는 기능을 메서드로 만들어 테스트 용이성을 높였다.

전진 기능은 RacingCar 도메인 클래스 내에 만들었고, 메서드는 인자로 '전진 전략' moveStrategy 객체를 받아서 전진 여부를 결정하도록 했다. 이 때 moveStrategy 객체는 인터페이스로 선언하여 추상화하였고, 구현 클래스는 랜덤 값을 사용하는 RandomMoveStrategy 클래스를 만들었다. RandomMoveStrategy 클래스는 RandomPicker 인터페이스를 의존성 주입 받아 랜덤 값을 사용하는 기능을 테스트 용이성을 높였다.

``` java
public class RacingCarService {

    private final MoveStrategy moveStrategy;

    public RacingCarService(MoveStrategy moveStrategy) {
        this.moveStrategy = moveStrategy;
    }

    public List<RacingCar> generateRacingCarList(List<String> carNames) {
        return carNames.stream().map(RacingCar::of).toList();
    }

    public void runCarRacing(List<RacingCar> racingCars, int moveCount) {
        IntStream.range(0, moveCount).forEach(i -> {
            racingCars.forEach(racingCar -> racingCar.moveForwardOneStep(moveStrategy));
            racingCars.forEach(RacingCar::printMoveStatus);
            System.out.println();
        });
    }
}

package racingcar.car;

import racingcar.strategy.MoveStrategy;

public class RacingCar {

    private final String carName;
    private int distance;

    public void moveForwardOneStep(MoveStrategy moveStrategy) {
        if (moveStrategy.canMove()) {
            distance += 1;
        }
    }
}

public class RandomMoveStrategy implements MoveStrategy {

    private final RandomPicker randomPicker;

    public RandomMoveStrategy(RandomPicker randomPicker) {
        this.randomPicker = randomPicker;
    }

    @Override
    public boolean canMove() {
        return randomPicker.pickNumberInRange(0, 9) >= 4;
    }
}
```
테스트 용이성을 높이게된 테스트 코드
``` java
class RacingCarServiceTest {

    private RacingCarService racingCarService;

    /**
     * 뽑게될 숫자 pickNumber을 인자로 하여 mockRandomPicker 생성 후 MoveStrategy 생성
     *
     * @param pickNumber - 레이싱카 뽑게 될 숫자
     * @return
     */
    private MoveStrategy createMoveStrategyWithMockPicker(int[] pickNumber) {
        RandomPicker randomPicker = new RandomPicker() {
            int index = 0;

            @Override
            public int pickNumberInRange(int min, int max) {
                return pickNumber[index++];
            }
        };

        return new RandomMoveStrategy(randomPicker);
    }
}
```

### 입출력 View 레이어 분리
1주차 과제에서는 입출력에 대한 레이어를 따로 작성하지 않았지만, 다른 지원자들의 코드와 입력 부분에서의 유효성 처리를 하는 것이 좋을 것 같아 만들게 됐다. 레이어를 나누는 것이 오히려 예외처리를 나누는 것에 더 도움이 되는 것 같다

### 도메인 출력 시 포매팅 하는 것이 좋을 지
레이싱 자동차 마다 현재 전진 상태를 출력을 OutputView에서만 처리하는 것이 좋을 지 아니면 RacingCar 도메인에서 포맷팅 후 출력하는 것이 좋을 지 고민을 했다. 처음에는 String으로 포맷한 문자열을 반환해 OutputView에서 출력하는 것이 좋을 것 같았는 데, 그럴거면 차라리 도메인에서 출력을 처리하는 것이 좋을 것 같아 도메인에서 출력했다.

이 선택은 지금와서 후회되지만 그냥 문자열로 만든 후 출력 역할만 담당하는 OutputView에서 처리 하는 것이 더 좋았을 듯 싶다.

### 요약
이번 과제를 하면서 랜덤 값 사용 기능 테스트 용이성, 입출력 View 레이어 분리, 도메인 출력 시 포매팅 하는 것이 좋을 지 고민을 하면서 많은 것을 배웠다. 특히 테스트 용이성을 높이는 것이 중요하다는 것을 깨달았고, 추상화를 통해 테스트 용이성을 높이는 것이 중요하다는 것을 깨달았다. 또한 입출력 레이어를 분리하는 것이 예외처리를 나누는 것에 더 도움이 되는 것 같다. 이번 과제를 통해 많은 것을 배웠고, 앞으로 남은 2주동안 열심히 해서 더욱 성장 해야겠다.
