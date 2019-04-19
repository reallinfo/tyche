#ifndef __STACK_H__
#define __STACK_h__

#include <stddef.h>
#include <stdlib.h>
#include <errno.h>

#define STACK_DEFAULT_SIZE		0x4
#define STACK_SCUESS			0x0
#define STACK_IS_NULL			0x1
#define STACK_BASE_IS_NULL		0x2
#define STACK_PUSH_ITEM_IS_NULL	0x3

#define DEFINE_GENERIC_STACK_TYPE(TYPE)\
	typedef struct {\
		size_t _size;\
		size_t _count;\
		size_t _type_size;\
		TYPE* _base;\
	} stack_##TYPE

#define DEFINE_GENERIC_STACK_CONSTRUCTOR(TYPE)\
	stack_##TYPE* stack_create_##TYPE()\
	{\
		stack_##TYPE* stack = malloc(sizeof(stack_##TYPE));\
		if(stack == NULL)\
			return NULL;\
		\
		stack->_size = STACK_DEFAULT_SIZE;\
		stack->_type_size = sizeof(stack_##TYPE);\
		stack->_count = 0x0;\
		\
		stack->_base = malloc(stack->_size * stack->_type_size);\
		if(stack->_base == NULL)\
			return NULL;\
		\
		return stack;\
	}

#define DEFINE_GENERIC_STACK_DESTRUCTOR(TYPE)\
	error_t stack_destroy_##TYPE(stack_##TYPE* stack)\
	{\
		if(stack == NULL)\
			return STACK_IS_NULL;\
		\
		free(stack->_base);\
		free(stack);\
	}

#define DEFINE_GENERIC_STACK_PUSH(TYPE)\
	error_t stack_push_##TYPE(stack_##TYPE* stack, TYPE* item_ptr)\
	{\
		if(stack == NULL)\
			return STACK_IS_NULL;\
		if(stack->_base == NULL)\
			return STACK_BASE_IS_NULL;\
		if(item_ptr == NULL)\
			return STACK_PUSH_ITEM_IS_NULL;\
		\
		if(stack->_size == stack->_count) {\
			stack->_size <<= 1;\
			\
			TYPE* new_base = malloc(stack->_type_size * stack->_size);\
			if(new_base == NULL)\
				return STACK_BASE_IS_NULL;\
			\
			for(size_t i = 0; i < stack->_count; i++)\
				new_base[i] = stack->_base[i];\
			\
			free(stack->_base);\
			\
			stack->_base = new_base;\
		}\
		\
		stack->_count++;\
		stack->_base[count] = *item_ptr;\
		\
		return STACK_SUCCESS;\
	}


#define __DEFINE_GENERIC_STACK__(TYPE)\
	DEFINE_GENERIC_STACK_TYPE(TYPE);\
	DEFINE_GENERIC_STACK_CONSTRUCTOR(TYPE);\
	DEFINE_GENERIC_STACK_DESTRUCTOR(TYPE);\
	DEFINE_GENERIC_STACK_PUSH(TYPE);\

#endif