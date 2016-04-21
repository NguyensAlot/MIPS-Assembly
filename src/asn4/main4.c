// prototype
int var2(void);
int var3(int l, int m, int n, int o, int p, int q);

void main(void)
{
    int i = 10;
    int j = 20;

    i = var2();
    j = i + 1;

}

int var2(void)
{
    int i = 10;
    int j = 20;

    i = var3(1, 2, 3, 4, 5, 6) + j;
    return (i);
}

int var3(int l, int m, int n, int o, int p, int q)
{
    int i = 10;
    int j = 20;
    int k = 30;

        k = i + j + l + m + n + o + p + q;

    return (k);
}