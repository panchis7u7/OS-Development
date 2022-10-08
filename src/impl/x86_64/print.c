#include "print.h"

const static size_t NUM_COLS = 80;
const static size_t NUM_ROWS = 25;

struct Char {
    uint8_t character;
    uint8_t color;
};

struct Char* buffer = (struct Char*) 0xb8000;
size_t column = 0;
size_t row = 0;
uint8_t color = 15 | 0 << 4; 

void rclear(size_t index) {
    struct Char empty = (struct Char) {
        character: ' ',
        color: color
    };

    for(size_t col = 0; col < NUM_COLS; ++col)
        buffer[col + NUM_COLS * index] = empty;
}

void clear() {
    for(size_t i = 0; i < NUM_ROWS; ++i)
        rclear(i);
}