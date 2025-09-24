// bgm.h
#ifndef BGM_H
#define BGM_H

// Note 타입 정의 (Note가 정의된 곳이 하나여야 합니다)
typedef struct {
    unsigned char tone;
    int           dur;
} Note;

// bgmTheme, bgm_timer, bgm_idx 전역 심볼
extern const Note   bgmTheme[];
extern const int    THEME_LEN;
extern volatile int bgm_timer;
extern volatile int bgm_idx;

// 함수 프로토타입
unsigned short SemitoneToFreq(unsigned char st);
void TIM3_Out_Freq_Generation(unsigned short freq);

#endif // BGM_H