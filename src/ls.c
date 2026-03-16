int manual_strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(unsigned char *)s1 - *(unsigned char *)s2;
}

void sort(char *arr[], int n) {
    for (int i = 0; i < n - 1; i++) {
        int min_idx = i;
        for (int j = i + 1; j < n; j++) {
            if (manual_strcmp(arr[j], arr[min_idx]) < 0) {
                min_idx = j;
            }
        }
        char *temp = arr[min_idx];
        arr[min_idx] = arr[i];
        arr[i] = temp;
    }
}
void sort_lines(char *str) {
    char *lines[1024]; 
    int count = 0;

    if (*str == '\0') return;

    lines[count++] = str;
    for (char *p = str; *p != '\0'; p++) {
        if (*p == '\n') {
            *p = '\0';
            if (*(p + 1) != '\0') {
                lines[count++] = p + 1;
            }
        }
    }

    sort(lines, count);

    char temp_buf[4096]; // Make sure this is large enough for your file list
    char *dest = temp_buf;

    for (int i = 0; i < count; i++) {
        char *src = lines[i];
        // Copy characters from sorted pointer to temp_buf
        while (*src != '\0') {
            *dest++ = *src++;
        }
        *dest++ = '\n'; // Add the newline back
    }
    *dest = '\0'; // Final null terminator

    char *src = temp_buf;
    while (*src != '\0') {
        *str++ = *src++;
    }
    *str = '\0';
}