
#include <stdio.h>
#include <stdint.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "sleep.h"

typedef struct {
	uint32_t CR;
	uint32_t FDR;
}FND_TypeDef;

typedef struct {
	uint32_t CR;
	uint32_t ODR;
	uint32_t IDR;
}GPIO_TypeDef;

#define FND_BASE	XPAR_FNDCONTROLLER_0_S00_AXI_BASEADDR
#define GPIO_BASE  	XPAR_GPIO_0_S00_AXI_BASEADDR
#define FND 		((FND_TypeDef *)(FND_BASE))
#define GPIO 		((GPIO_TypeDef *)(GPIO_BASE))

void FND_Init(FND_TypeDef *fnd)
{
	fnd->CR = 0x01;
}

void FND_WriteData(FND_TypeDef *fnd, uint32_t data)
{
	fnd->FDR = data;
}

uint8_t FND_ReadData(FND_TypeDef *fnd, uint32_t data)
{
	return fnd->FDR;
}

void GPIO_Init(GPIO_TypeDef *gpio, uint8_t data)
{
	gpio->CR = data;
}

void GPIO_WriteData(GPIO_TypeDef *gpio, uint8_t data)
{
	gpio->ODR = data;
}

uint8_t GPIO_ReadData(GPIO_TypeDef *gpio)
{
	return gpio->IDR;
}

int main()
{
	uint32_t counter = 0;
	uint8_t led = 0;

	FND_Init(FND);
	GPIO_Init(GPIO, 0x0f);

	for(;;)
	{
		FND_WriteData(FND, counter);
		GPIO_WriteData(GPIO, led);
		counter++;
		led = led ^ 0x0f;
		usleep(100000); // 0.1s
	}

    return 0;
}
