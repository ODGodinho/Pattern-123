<?php

declare(strict_types=1);

namespace App\Services;

use Illuminate\Support\Facades\Validator;
use Throwable;

class ServiceBase
{
    /**
     * Undocumented function
     *
     * @param array<string> $data
     * @param string $validationClassName
     *
     * @throws Throwable Erro ao validar os dados.
     * @return array<string>
     */
    protected function validate(array $data, string $validationClassName): array
    {
        /** @var mixed $validationClass */
        $validationClass = app($validationClassName);

        $messages = method_exists($validationClass, "messages") ? $validationClass->messages() : [];
        $validator = Validator::make($data, $validationClass->rules(), $messages);

        try {
            return $validator->validated();
        } catch (Throwable $th) {
            // set error to response
            throw $th;
        }
    }
}
