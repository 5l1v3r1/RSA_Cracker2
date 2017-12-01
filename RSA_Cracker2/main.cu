#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <string>
#include <math.h>

#include <stdio.h>

struct RSA_KEY
{
	unsigned long p; // selected prime 1
	unsigned long q; // selected prime 2
	unsigned long n; // public - the modulus
	unsigned long e; // public - for encryption
	unsigned long d; // private - for decryption
};

// Function prototypes
RSA_KEY generate_RSA_key();
void print_RSA_key(RSA_KEY in_key);
void RSA_encode(
	char *input,
	size_t input_size,
	unsigned long long *output,
	size_t output_size,
	unsigned long e,
	unsigned long n);
void RSA_decode(
	unsigned long long *input,
	size_t input_size,
	char *output,
	size_t output_size,
	unsigned long d,
	unsigned long n);
int gcd(int a, int b);
int modulo(int a, int b, int n);

int main()
{
	// Message to encode
	char secret_message[] = "The quick brown fox jumped over the lazy dog.";
	printf("Message: %s\n\n",secret_message);

	// Generate public & private key
	printf("Generating key...\n");
	RSA_KEY my_key;
	my_key = generate_RSA_key();
	print_RSA_key(my_key);

	// Encode message using public key
	printf("Encrypting message...\n");
	unsigned long long ciphertext[50];
	RSA_encode(secret_message, sizeof secret_message, ciphertext, sizeof ciphertext, my_key.e, my_key.n);
	
	printf("Ciphertext : ");
	for (int i = 0; i < sizeof(secret_message); i++)
	{
		if (i % 10 == 0) { printf("\n"); }
		printf("%6d ", ciphertext[i]);
	}

	// Decrypt message using private key
	printf("\n\nDecrypting using private key...\n");
	char decrypt_message[50];
	RSA_decode(ciphertext, sizeof ciphertext, decrypt_message, sizeof decrypt_message, my_key.d, my_key.n);
	printf("Decrypted message: %s\n", decrypt_message);

	// Attempt to bruteforce find the private key

	// Decrypt message using 
	
	
	
	printf("\nEnd Program\n");
}

RSA_KEY generate_RSA_key()
{
	RSA_KEY ret_str;

	ret_str.p = 11; // TODO: hardcoded for now - needs random generation
	ret_str.q = 13; // TODO: hardcoded for now - needs random generation

	// Calculate modulus
	ret_str.n = ret_str.p * ret_str.q;

	// Calculate totient
	int totient = (ret_str.p - 1) * (ret_str.q - 1);
	printf("Totient: %d\n", totient);

	// Calculate public key exponent 'e'
	int temp_e = 0;
	while (true)
	{
		temp_e = rand() % totient + 1; // random int  1 < e < totient
		if (gcd(temp_e, totient) == 1)
		{
			break;
		}
	}
	ret_str.e = temp_e;

	// Calculate private key exponent 'd'
	int temp_d = 0;
	int diff;
	while (true)
	{
		temp_d++;
		diff = (temp_d * ret_str.e) - 1;
		if(diff % totient == 0)
		{
			break;
		}
	}
	ret_str.d = temp_d;

	return ret_str;
}

void print_RSA_key(RSA_KEY in_key)
{
	printf("RSA Key: p = %d\n", in_key.p);
	printf("RSA Key: q = %d\n", in_key.q);
	printf("RSA Key: n = %d\n", in_key.n);
	printf("RSA Key: e = %d\n", in_key.e);
	printf("RSA Key: d = %d\n", in_key.d);
	printf("\n");
}

// Greatest Common Denominator function
// Courtest of: https://codereview.stackexchange.com/a/39110
int gcd(int a, int b)
{
	int x;
	while (b)
	{
		x = a % b;
		a = b;
		b = x;
	}
	return a;
}

// RSA Message encoder
void RSA_encode(
	char *input,
	size_t input_size,
	unsigned long long *output,
	size_t output_size,
	unsigned long e,
	unsigned long n)
{
	unsigned long long m,c,p;
	//printf("e: %d n: %d\n", e, n);

	// Convert message string to integer
	for (int i = 0; i < input_size; i++)
	{
		m = (int)input[i]; //printf("m: %d ", m);
		//p = pow(m, e); printf("p: %d\n", p);
		//c = p % n;
		c = modulo(m, e, n);
		//printf("c: %d\n", c);
		output[i] = c;
	}
}

// RSA Message decoder
void RSA_decode(
	unsigned long long *input,
	size_t input_size,
	char *output,
	size_t output_size,
	unsigned long d,
	unsigned long n)
{
	for (int i = 0; i < output_size; i++)
	{
		output[i] = modulo(input[i], d, n);
	}
}

// Modulo Function for massive powers
// Courtest of: https://stackoverflow.com/a/36398956
int modulo(int a, int b, int n) {
	long long x = 1, y = a;
	while (b > 0) {
		if (b % 2 == 1) {
			x = (x*y) % n;
		}
		y = (y*y) % n; // squaring the base
		b /= 2;
	}
	return x%n;
}